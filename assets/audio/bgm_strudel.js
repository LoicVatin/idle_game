// Basic BGM loop
// Composed on strudel.cc

$kick: s("[bd bd bd <bd [bd bd]>]").bank("RolandSystem100").dec(.4)._scope()
$hum: note("<g1 bb1 d2 <f1 c2>>").layer(
    x=>x.s("sawtooth, wt_vgame").vib(4),
    x=>x.s("square").add(note(12))
)._scope()