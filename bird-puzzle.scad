tolerance = .5;
slices = 60;
$fn=64;
show_complement=true;

module half_circle() {
    intersection() {
        circle(25);
        translate([-50, 0, 0])
        square(100);
    }
}

module half_plane() {
    translate([-50, 0, 0])
    square(50);
}

module screw(height, twist, sign) {
    linear_extrude(height, twist=twist, slices=slices) {
        offset(delta=sign*tolerance/2)
        half_circle();
    }
}

module animated_screw(height, twist) {
    union() {
        color("red")
        screw(height, twist);

        color("blue")
        rotate([0, 0, 180 - $t * twist])
        translate([0, 0, $t * height])
        screw(height, twist);
    }
}

$t=0;
*animated_screw(40,360);


module stair_extrude(height, twist, slices=slices) {
    for(a=[0:slices-1]) {
        rotate([0, 0, -a*twist/slices])
        translate([0, 0, a*height/slices])
        linear_extrude(height/slices, slices = 1)
        children();
    }
}

module stair_screw(height, twist) {
    stair_extrude(height, twist, slices)
    half_plane();
    //half_circle();
}

*stair_screw(40, 360);

module yinyang_dot1(fn) {
    translate([10,0])
    circle(d=10, $fn=fn);
}

module yinyang_dot2(fn) {
    translate([-10,0])
    circle(d=10, $fn=fn);
}

module yinyang(dots = true, fn=180) {
    module base() {
        difference() {
            union() {
                intersection() {
                    translate([-20, 0])
                    square([40, 20]);
                    circle(d=40, $fn=fn);
                }
                translate([10,0])
                circle(d=20, $fn=fn/2);
            }
            translate([-10,0])
            circle(d=20, $fn=fn/2);
        }
    }
    if(dots) {
        difference() {
            base();
            yinyang_dot1(fn=fn/2);
        }
        yinyang_dot2(fn=fn/2);
    } else {
        base();
    }
}

module yinyang_screw(height, twist) {
    module one() {
        linear_extrude(height, twist=twist, slices=slices) {
            offset(r=-tolerance)
            yinyang();
        }
    }
    color("blue")
    one();
    if(show_complement) {
        color("red")
        translate([0, 0, 0])
        rotate([0, 0, 180])
        scale([1, 1, 1])
        one();
    }
}

module animated_yinyang_screw(height, twist) {
        union() {
            color("red")
            yinyang_screw(height, twist);

            color("blue")
            rotate([0, 0, 180 - $t * twist])
            translate([0, 0, $t * height])
            yinyang_screw(height, twist);
        }
}

module yinyang_locking_screw(height, twist, fn=180) {
    module base_screw() {
        linear_extrude(height, twist=twist, slices=slices) {
            offset(r=-tolerance)
            yinyang(dots=false, fn=fn);
        }
    }
    module pin1(tolerance=0) {
        linear_extrude(height, twist=-twist, slices=slices) {
            offset(r=-tolerance)
            yinyang_dot1(fn=fn/4);
        }
    }
    module pin2(tolerance=0) {
        linear_extrude(height, twist=-twist, slices=slices) {
            offset(r=-tolerance)
            yinyang_dot2(fn=fn/4);
        }
    }
    module one() {
        difference() {
            base_screw();
            pin1();
            pin2();
        }
        translate([40, 0, 0])
        pin1(tolerance=tolerance);
    }
    color("blue")
    one();
    if(show_complement) {
        color("red")
        translate([0, 0, 0])
        rotate([0, 0, 180])
        scale([1, 1, 1])
        one();
    }
}


*animated_yinyang_screw(40,360);
*yinyang_screw(40,180);
*yinyang();
*yinyang_locking_screw(80, 360);

module tetra() {
    a=atan2(sqrt(6)/3, sqrt(3)/6)/2;
    
    polyhedron(points = [
          [ 0,  0,  0 ],  //0
          [ 0,  1,  0 ],  //1
          [ sqrt(3)/2,  .5,  0 ],  //2
          [ sqrt(3)/6,  0.5,  sqrt(6)/3 ],  //3
        ],
        faces = [
            [0,2,1],  // bottom
            [0,1,3],
            [1,2,3],
            [2,0,3],
        ]
    );
}

module scaled_tetra() {
    translate([0, -10, 0])
    scale(20)
    tetra();
}

tetra_dihedral_angle = acos(1/3);
tetra_screw_angle = (90 - tetra_dihedral_angle/2);

module tetra_screw(twist) {    
    module one() {       
        intersection() {
            scaled_tetra();
            
            rotate([0, tetra_screw_angle, 0])
            stair_screw(20/sqrt(2), twist);
        }
    }
    
    color("blue")
    one();
    
    if(show_complement) {
        translate([20, 0, 0])
        color("red")
        rotate([0, 0, 90])
        rotate([180-tetra_dihedral_angle, 0, 0])
        rotate([0, 0, 90])
        one();
    }
}



*tetra_screw(-360-90);
//render()

module hart_tetra() {
    module one() {
        rotate([0, 0, 3.5])
        translate([15.444, -3.233, 0])
        import("hart-tetra-puzzle.stl");
    }
    color("white")
    one();

    rotate([0, 0, 90])
    rotate([180-tetra_dihedral_angle, 0, 0])
    rotate([0, 0, 90])
    color("green")
    one();
}


module redone_hart_tetra() {
    scale(3.1165)
    tetra_screw(-(360+90));
}


*hart_tetra();

translate([60,0,0])
redone_hart_tetra();


module screw_on_cube_diagonal(twist) {
    rotate(atan2(sqrt(2), 1), [-1, 1, 0])
    rotate([0,0,45])
    scale([2,2,1])
    screw(20*sqrt(3), twist);
}

module bird(size=1) {
    //rotate([90, 0, 0])
    scale(size)
    translate([0, 0, -18.22])
//+    import("birdV2.stl");
    import("bird-8k.stl");
}

module bird_screw() {
    twist = 180*3;
    angle = 40;
    height = 60;
    
    module model() {
        bird(1);
    }
    
    module cutter(sign = 1) {
        #
        translate([-height/2,0,10])
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

*!screw(60,180*3,1);

orientations = [
    [0,0,0],
    [90,0,0],
    [180,0,0],
    [-90,0,0],
    [0,0,90],
    [0,0,-90],
];

dts=[-180,-90,0,90,180, 270];

*for(dti=[0:len(dts)-1]) {
    translate([0, 0, 30*dti])

    translate([10, 10, 10])
    for(i=[0:len(orientations)-1]) {
        translate([30*i, 0, 0])
        rotate(orientations[i])
        translate([-10, -10, -10])
        cube_screw(360+dts[dti]);
    }
}



//translate([0, 0, 20])
//rotate([-90, 0, 0])
!bird_screw();

