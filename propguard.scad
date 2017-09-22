// radius of guard
r = 200; 

// width of supports
w = 10; 

// thickness of guard
t = 10; 

// outer thickness of guard, used in 3d version
to = 5; 

// start angle of guard
angle_start = -70;

// stop angle of guard
angle_stop = 70; 

// number of supports inside guard
n_supports = 2; 

// diameter of motor
d_motor = 50; 

// diameter of motor screws
d_screw = 3;

// triangular screw separation, setup for tarot motors
screw_sep = 28;


// Which one would you like to see?
part = "propguard_3d"; // [propguard_3d:3D version good for 3D printing, propguard_2d:2D version, good for routing, all: display everything]

module outset(r) {
    minkowski() {
        circle(r=r);
        children();
    }
}

module inverse() {
	difference() {
		square(1e5,center=true);
		children();
	}
}

module fillet(r=1) {
	inset(r=r) render() outset(r=r) children();
}

module rounding(r=1) {
	outset(r=r) inset(r=r) children();
}

module inset(r) {
    inverse() outset(r) inverse() children();
}

module pie_slice(r, start_angle, end_angle) {
    R = r * sqrt(2) + 1;
    a0 = (4 * start_angle + 0 * end_angle) / 4;
    a1 = (3 * start_angle + 1 * end_angle) / 4;
    a2 = (2 * start_angle + 2 * end_angle) / 4;
    a3 = (1 * start_angle + 3 * end_angle) / 4;
    a4 = (0 * start_angle + 4 * end_angle) / 4;
    if(end_angle > start_angle)
        intersection() {
        circle(r);
        polygon([
            [0,0],
            [R * cos(a0), R * sin(a0)],
            [R * cos(a1), R * sin(a1)],
            [R * cos(a2), R * sin(a2)],
            [R * cos(a3), R * sin(a3)],
            [R * cos(a4), R * sin(a4)],
            [0,0]
       ]);
    }
}

module guard_shape(r, w, t, angle_start, angle_stop, n_supports, d_motor, mount_r) {
    render() {
        pie_slice(mount_r, angle_start, angle_stop);
        difference() {
            outset(r=w) pie_slice(r, angle_start, angle_stop);
            pie_slice(r, angle_start, angle_stop);
        }
        delta_angle = (angle_stop - angle_start) / (n_supports + 1);
        for (n = [1: 1: n_supports]) {
            a = angle_start + n*delta_angle;
            rotate(a) translate([r/2, 0]) square([r, w], center=true);
        }
    }
}

module drill_holes(d, sep) {
    x = sep / 2 / cos(30);
    for (angle=[0:120:360]) {
        rotate(angle) translate([x, 0]) circle(d=d);
    }
}

module guard_2d(r, w, t, angle_start, angle_stop, n_supports, d_motor, mount_r=0) {
    if (mount_r == 0) {
        mount_r = d_motor/2;
    }
    difference() {
        fillet(r=w) union() {
            guard_shape(r, w, t, angle_start, angle_stop, n_supports, d_motor, mount_r);
            drill_holes(d=d_screw*3, sep=screw_sep);
        }
        drill_holes(d=d_screw, sep=screw_sep);
    }
}

module guard_3d(r, w, t, angle_start, angle_stop, n_supports, d_motor, to) {
    ro = r;
    ri = d_motor/2;
    ti = t;
    r2 = (ro*ti - ri*to)/(ti - to);
    mount_r = d_motor/2 + w;
    render() difference() {
        intersection() {
            linear_extrude(t) guard_2d(r, w, t, angle_start,
                angle_stop, n_supports, d_motor, mount_r);
            cylinder(h=t, r1=r2, r2=d_motor/2);
        }
        motor();
    }
}

module motor() {
    translate([0, 0, 2]) color("blue", 0.1) linear_extrude(20) circle(d=d_motor);
}

module print_part() {
	if (part == "propguard_2d") {
    	guard_2d(r, w, t, angle_start, angle_stop, n_supports, d_motor);
	} else if (part == "propguard_3d") {
    	guard_3d(r, w, t, angle_start, angle_stop, n_supports, d_motor, to);
	} else if (part == "all") {
    	guard_2d(r, w, t, angle_start, angle_stop, n_supports, d_motor);
    	guard_3d(r, w, t, angle_start, angle_stop, n_supports, d_motor, to);
		motor();
	}
}

print_part();
