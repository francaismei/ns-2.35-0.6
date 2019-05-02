set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             50                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              500                        ;# X dimension of the topography
set val(y)              500                        ;# Y dimension of the topography

set ns [new Simulator]

set tracefd [open example2.tr w]
$ns  trace-all $tracefd
set namtracefd [open example2.nam w]
$ns namtrace-all-wireless $namtracefd $val(x) $val(y)

proc finish {} {
        global ns tracefd namtracefd
        $ns flush-trace

        close $tracefd
        close $namtracefd
        
        exec nam example2.nam &
        exit 0    
}

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#Create-God  
set god_  [create-god $val(nn)]

#create channel
set chan [new $val(chan)]

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channel $chan \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace ON                        
                         
for {set i 0} {$i < $val(nn) } {incr i} {
        set node_($i) [$ns node]        
        $node_($i) random-motion 0                ;# disable random motion
}

$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 20.0
$node_(2) set Y_ 35.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 115.0
$node_(3) set Y_ 120.0
$node_(3) set Z_ 0.0

$ns at 10.0 "$node_(0) setdest 20.0 18.0 1.0"
$ns at 50.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns at 100.0 "$node_(1) setdest 490.0 480.0 15.0" 
$ns at 20.0 "$node_(2) setdest 70.0 50.0 10.0"
$ns at 15.0 "$node_(3) setdest 90.0 100.0 15.0"


set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start" 

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns at 150.0 "$node_($i) reset";
}
$ns at 150.0 "finish"
$ns run
