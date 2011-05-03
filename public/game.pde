g = window.game;
int gridSize, dotSize, gap;
Edge[] edges = [];
PImage[] profilePics = {};
int hoveredEdge = 0;

class Edge {
	int edgeNum;
	int x1, x2;
	int y1, y2;

	Edge(int anEdgeNum) {
		edgeNum = anEdgeNum;

		boolean isVertical = g.isVerticalEdge(edgeNum);
		int rowNum = (int)(edgeNum / g.alpha);
		int col = edgeNum % g.alpha;
		if (isVertical) col -= gridSize - 1;

		x1 = x2 = col * gap;
		y1 = y2 = rowNum * gap;

		if (isVertical) {
			y2 += gap;
		} else {
			x2 += gap;
		}
	}

	boolean isMouseHovering() {
		return ((x1 == x2 && y1 < mouseY && mouseY < y2 && abs(mouseX - x1) < 15) ||
			(y1 == y2 && x1 < mouseX && mouseX < x2 && abs(mouseY - y1) < 15));
	}

	boolean shouldHighLight() {
		boolean isFilled = g.board[edgeNum];
		return !isFilled && isMouseHovering();
	}

	boolean shouldDraw() {
		boolean isFilled = g.board[edgeNum];
		return isFilled;
	}

	void draw() {
		pushMatrix();
			int delta = dotSize/2;
			translate(delta, delta);
			strokeWeight(dotSize + 3);
			line(x1, y1, x2, y2);
		popMatrix();
	}
}

void mouseClicked() {
	g.emit('fillEdge', hoveredEdge);
}

void setup() {
	frameRate(30);
	// noLoop();

	size(500, 500);
	stroke(255);
	smooth();

	g = window.game;
	gridSize = g.size;
	dotSize = 3;
	gap = (width - dotSize) / (gridSize - 1);

	boolean[] board = g.board;
	for (int edgeNum = 0; edgeNum < board.length; edgeNum++) {
		edges[edgeNum] = new Edge(edgeNum);
	}
}

void draw() {
	background(16);
	drawCompletedSquares();
	drawGrid();
	drawEdges();

	//drawDancingBox();
}

void drawCompletedSquares() {
	for (String uid in g.completedSquares) {
		int[] topEdges = g.completedSquares[uid];
		for (int idx = 0; idx < topEdges.length; idx++) {

			PImage img;
			if (!profilePics[uid]) {
				profilePics[uid] = loadImage("http://graph.facebook.com/" + uid + "/picture");
			}
			img = profilePics[uid];

			if (img.loaded) {
				Edge e = new Edge(topEdges[idx]);
				image(img, e.x1 + 25, e.y1 + 25);
			}
		}
	}
}

void drawGrid() {
	int curX = 0;
	int curY = 0;
	
	for (int i = 0; i < gridSize; i++) {
		curX = i * gap;
		for (int j = 0; j < gridSize; j++) {
			curY = j * gap;
			rect(curX, curY, dotSize, dotSize);
		}
	}
}

void drawEdges() {
	stroke(255);
	Edge highlighted = null;
	for (int i = 0; i < edges.length; i++) {
		if (edges[i].shouldDraw()) edges[i].draw();
		if (edges[i].shouldHighLight()) highlighted = edges[i];
	}

	if (highlighted) {
		hoveredEdge = highlighted.edgeNum;
		int redValue = ((sin(frameCount/2) + 1) * 127.5) + 100;
		stroke(redValue, 0, 0);
		highlighted.draw();
		stroke(255);
	}
}

int delta = 3;
int newX = 0;
int radius = 50;
void drawDancingBox() {
	pushMatrix();
		translate(0, height/2);
		newX += delta;
		int newY = 30 * sin(frameCount / 8);

		if (newX + 50 > width || newX < 0) {
			delta *= -1
		}

		rect(newX, newY, 50, 50);
	popMatrix();
}

