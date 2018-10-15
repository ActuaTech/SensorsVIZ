PFont myFont;

boolean run = false;

PImage BG;
boolean showBG = true;
boolean surfaceMode = true;

// PROJECTION 3D MODEL
WarpSurface surface;
//Canvas canvas;
PGraphics canvas;

// SIMULACIÓ FONS DE VALL
int simWidth = 1000;
int simHeight = 847;
final String bgPath = "orto_small.jpg";
final PVector[] bounds = new PVector[] {
    new PVector(42.482119, 1.489794),
    new PVector(42.533768, 1.572122)
};
PVector[] roi = new PVector[] {
    new PVector(42.505086, 1.509961),
    new PVector(42.517066, 1.544024),
    new PVector(42.508161, 1.549798),
    new PVector(42.496164, 1.515728)
};

final PVector point = new PVector(42.505086, 1.509961);
PVector pointCorrected;

void setup() {
    fullScreen(P2D,1);
    smooth();
    
    myFont = createFont("Montserrat-Light", 32);
    
    BG = loadImage(bgPath);
    simWidth = BG.width;
    simHeight = BG.height;
    
    surface = new WarpSurface(this, 900, 300, 10, 5);
    surface.loadConfig();
    canvas = new Canvas(this, simWidth, simHeight, bounds, roi);
    
    pointCorrected = toXY(point);
}


void draw() {
    
    background(255);
    
    canvas.beginDraw();
    canvas.background(255);
    if(showBG)canvas.image(BG, 0, 0);
    canvas.fill(#ff0000);
    canvas.ellipse(pointCorrected.x, pointCorrected.y, 10, 10);
    canvas.endDraw();
    
    //surface.draw((Canvas)canvas);
    image(canvas, 0 ,0);
}


void keyPressed() {

    switch(key) {
        case 'b':
            showBG = !showBG;
            break;
            
        case 'w':
            surface.toggleCalibration();
            break;
    }
    
}



PVector toXY(PVector coords) {
    return new PVector(
        map(coords.y, bounds[0].y, bounds[1].y, 0, simWidth),
        map(coords.x, bounds[0].x, bounds[1].x, simHeight, 0)
    );
}
