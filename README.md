# Barren Land Analysis (Swift 4)

## Summary

Swift 4.0.3 application that outputs areas of all fertile regions in a 400m by 600m farm land. A portion of the farm land is barren and each barren region is rectangular represented by its bottom left and top right x and y coordinates.

## Tech Stack

* Swift 4.0.3

### Running (Command Line)

* Clone this repo to your local machine

* Compile the only Swift file  **"BarrenLandAnalyzer.swift"** - `swiftc BarrenLandAnalyzer.swift`

* Run the compiled file passing the barren land rectangle coordinates as arguments

<pre><code>Dayals-MacBook-Pro:barren-land-analyzer-swift dayal$ ./BarrenLandAnalyzer 0 292 399 307
processing with coordinates: 0 292 399 307
created farm model
marked barren land in farm model
processed farm
116800 116800
time taken: 2.01343500614166 seconds

Dayals-MacBook-Pro:barren-land-analyzer-swift dayal$ ./BarrenLandAnalyzer 48 192 351 207,48 392 351 407,120 52 135 547,260 52 275 547
processing with coordinates: 48 192 351 207,48 392 351 407,120 52 135 547,260 52 275 547
created farm model
marked barren land in farm model
processed farm
22816 192608
time taken: 1.91312897205353 seconds
Dayals-MacBook-Pro:barren-land-analyzer-swift dayal$</code></pre>
