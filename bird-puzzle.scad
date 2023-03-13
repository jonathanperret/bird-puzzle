tolerance = .5;
slices = 60;
$fn=64;
show_complement=true;

module half_circle(r) {
    intersection() {
        circle(r=r);
        translate([-50, 0, 0])
        square(100);
    }
}

module screw(height, twist, sign, r=30) {
    linear_extrude(height, twist=twist, slices=slices) {
        offset(delta=sign*tolerance/2)
        half_circle(r);
    }
}

module bird(size=1) {
    //rotate([90, 0, 0])
    scale(size)
    translate([0, 0, -18.22])
//+    import("birdV2.stl");
    import("bird-8k.stl");
}

module bird_screw() {
    twist = 180*5;
    angle = 190;
    height = 62;
    shift = -1;
    
    module model() {
        bird(1);
    }
    
    module cutter(sign = 1) {
        #
        translate([shift - height/2,0,10])
        rotate([0,90,0])
        rotate([0,0,angle])
        screw(height, twist, sign);
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

!bird_screw_vertical();


