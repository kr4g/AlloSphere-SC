s.boot;

(
Server.killAll;
~nChans = 54;
~sr = 48000;
s = Server.local;
s.options.outDevice_(
	"MacBook Pro Speakers"
	// "ZoomAudioD"
	// "Audio Out"
	// "Ryan’s AirPods P"
	// "External Headphones"
	// "BESTISAN SE07D"
	// "Scarlett 4i4 USB"
	// "Klipsch One II"
	// "UMC1820"
);
// s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(~nChans);
s.options.numInputBusChannels_(0);
s.options.sampleRate_(~sr);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
s.waitForBoot({
	s.plotTree;
	s.meter;
});
)

(
var speakerPositions, sortedChannels, vbapDirections;

speakerPositions = Dictionary[
    1 -> Dictionary[\az -> -77.660913, \ele -> 41.0],
    2 -> Dictionary[\az -> -45.088015, \ele -> 41.0],
    3 -> Dictionary[\az -> -14.797289, \ele -> 41.0],
    4 -> Dictionary[\az -> 14.797289, \ele -> 41.0],
    5 -> Dictionary[\az -> 45.088015, \ele -> 41.0],
    6 -> Dictionary[\az -> 77.660913, \ele -> 41.0],
    7 -> Dictionary[\az -> 102.339087, \ele -> 41.0],
    8 -> Dictionary[\az -> 134.911985, \ele -> 41.0],
    9 -> Dictionary[\az -> 165.202711, \ele -> 41.0],
    10 -> Dictionary[\az -> -165.202711, \ele -> 41.0],
    11 -> Dictionary[\az -> -134.911985, \ele -> 41.0],
    12 -> Dictionary[\az -> -102.339087, \ele -> 41.0],

    17 -> Dictionary[\az -> -77.660913, \ele -> 0.0],
    18 -> Dictionary[\az -> -65.647587, \ele -> 0.0],
    19 -> Dictionary[\az -> -54.081600, \ele -> 0.0],
    20 -> Dictionary[\az -> -42.869831, \ele -> 0.0],
    21 -> Dictionary[\az -> -31.928167, \ele -> 0.0],
    22 -> Dictionary[\az -> -21.181024, \ele -> 0.0],
    23 -> Dictionary[\az -> -10.559657, \ele -> 0.0],
    24 -> Dictionary[\az -> 0.0, \ele -> 0.0],
    25 -> Dictionary[\az -> 10.559657, \ele -> 0.0],
    26 -> Dictionary[\az -> 21.181024, \ele -> 0.0],
    27 -> Dictionary[\az -> 31.928167, \ele -> 0.0],
    28 -> Dictionary[\az -> 42.869831, \ele -> 0.0],
    29 -> Dictionary[\az -> 54.081600, \ele -> 0.0],
    30 -> Dictionary[\az -> 65.647587, \ele -> 0.0],
    31 -> Dictionary[\az -> 77.660913, \ele -> 0.0],
    32 -> Dictionary[\az -> 102.339087, \ele -> 0.0],
    33 -> Dictionary[\az -> 114.352413, \ele -> 0.0],
    34 -> Dictionary[\az -> 125.918400, \ele -> 0.0],
    35 -> Dictionary[\az -> 137.130169, \ele -> 0.0],
    36 -> Dictionary[\az -> 148.071833, \ele -> 0.0],
    37 -> Dictionary[\az -> 158.818976, \ele -> 0.0],
    38 -> Dictionary[\az -> 169.440343, \ele -> 0.0],
    39 -> Dictionary[\az -> 180.0, \ele -> 0.0],
    40 -> Dictionary[\az -> -169.440343, \ele -> 0.0],
    41 -> Dictionary[\az -> -158.818976, \ele -> 0.0],
    42 -> Dictionary[\az -> -148.071833, \ele -> 0.0],
    43 -> Dictionary[\az -> -137.130169, \ele -> 0.0],
    44 -> Dictionary[\az -> -125.918400, \ele -> 0.0],
    45 -> Dictionary[\az -> -114.352413, \ele -> 0.0],
    46 -> Dictionary[\az -> -102.339087, \ele -> 0.0],

    49 -> Dictionary[\az -> -77.660913, \ele -> -32.5],
    50 -> Dictionary[\az -> -45.088015, \ele -> -32.5],
    51 -> Dictionary[\az -> -14.797289, \ele -> -32.5],
    52 -> Dictionary[\az -> 14.797289, \ele -> -32.5],
    53 -> Dictionary[\az -> 45.088015, \ele -> -32.5],
    54 -> Dictionary[\az -> 77.660913, \ele -> -32.5],
    55 -> Dictionary[\az -> 102.339087, \ele -> -32.5],
    56 -> Dictionary[\az -> 134.911985, \ele -> -32.5],
    57 -> Dictionary[\az -> 165.202711, \ele -> -32.5],
    58 -> Dictionary[\az -> -165.202711, \ele -> -32.5],
    59 -> Dictionary[\az -> -134.911985, \ele -> -32.5],
    60 -> Dictionary[\az -> -102.339087, \ele -> -32.5]
];

sortedChannels = speakerPositions.keys.asArray.sort;
vbapDirections = sortedChannels.collect({ |chanNum|
    [speakerPositions[chanNum][\az], speakerPositions[chanNum][\ele]]
});

~vbapArray = VBAPSpeakerArray(3, vbapDirections);
~vbapBuffer = ~vbapArray.loadToBuffer;

"VBAP Array created with % speakers".format(sortedChannels.size).postln;
"Speaker channels: %".format(sortedChannels).postln;
"Buffer allocated: %".format(~vbapBuffer.bufnum).postln;
)

(
SynthDef(\vbapPanner, {
    arg azimuth = 0, elevation = 0, spread = 0;
    var source, panned;

    source = PinkNoise.ar(0.1);

    panned = VBAP.ar(
        numChans: ~vbapArray.numSpeakers,
        in: source,
        bufnum: ~vbapBuffer,
        azimuth: azimuth,
        elevation: elevation,
        spread: spread
    );

    Out.ar(0, panned);
}).add;
)

(
~panSynth = Synth(\vbapPanner);

~panTask = Task({
    loop {
        ~panSynth.set(
            \azimuth, rrand(-180, 180),
            \elevation, rrand(-30, 30),
            \spread, rrand(0, 20)
        );
        rrand(0.5, 2.0).wait;
    }
}).start;
)

~panTask.stop;
~panSynth.free;