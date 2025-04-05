run("Z Project...", "projection=[Max Intensity]");
run("Gaussian Blur...", "sigma=2");
run("Find Maxima...", "prominence=10 strict exclude output=[Point Selection]");
run("Measure");
