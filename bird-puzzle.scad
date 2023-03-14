tolerance = .5;

fast=false;

slices = fast ? 20 : 80;
$fn = fast ? 16 : 64;

show_complement=true;

module half_circle(r, angle=180) {
    intersection() {
        circle(r=r);
        translate([-50, 0, 0])
        square(100);
        
        rotate([0, 0, 180-angle])
        translate([-100, 0, 0])
        square(200);
    }
}

module screw(height, twist, sign, r=30, angle=180) {
    linear_extrude(height, twist=twist, slices=slices) {
        offset(delta=sign*tolerance/2)
        half_circle(r, angle);
    }
}

*screw(100,360,1,angle=180);

module bird(size=1) {
    //rotate([90, 0, 0])
    scale(size)
    translate([0, 0, -18.22])
//+    import("birdV2.stl");
    import(fast ? "bird-1k.stl" : "bird-8k.stl");
}

module bird_screw() {
    twist = 180*3;
    angle = 45;
    height = 70;

    
    module model() {
        bird(1);
    }
    
    module cutter(sign = 1, angle=angle) {
    #
        translate([-height/2,0,10])
        rotate([0,90,0])
        rotate([0,0,angle])
        screw(height, twist, sign, angle=120, r=20);
    }
    
    translate([50, 0, 0])
    intersection()
    {
        model();
        cutter(-1, angle=120+angle);
    }
    
    translate([30, 26, 0])
    intersection()
    {
        model();
        cutter(-1);
    }

    // flipped for better bed adhesion
    translate([0,0,28.9])
    rotate([180,0,0])
    intersection()
    {
        model();
        cutter(-1, angle=240+angle);
    }
}

module bird_screw_vertical() {
    twist = 180*3;
    angle = 190;
    height = 40;
    
    module model() {
        bird(1);
    }
    
    module cutter(sign = 1) {
        #
        translate([0,0,-0.1])
        //rotate([0,90,0])
        rotate([0,0,angle])
        screw(height, twist, sign, r=40);
    }
    
    difference()
    {
        model();
        cutter(1);
    }
    
    if(show_complement) {

        translate([0, 26, 0])
        intersection()
        {
            model();
            cutter(-1);
        }
    }
}

bird_screw();
