# cochlear-implant

Rudimentary signal processor for cochlear implants. This repository contains the end-to-end functions for generating audio waveforms with audio files, and separating the sounds into passband filters of varying frequencies. The output signal emulating the sound received by the user will be the summation of the separated and filtered signals.

![processor diagram](https://github.com/yun-kim/cochlear-implant/raw/master/img/signal-processor-diagram.png)
### Figure 1. Characteristic diagram of signal processor.

# Filters 
2 major categories were evaluated: Finite Impulse Response (FIR) filters and Infinite Impulse Response (IIR). 
## Finite Impulse Response (FIR)
FIR filters (Kaiser window, Equiripple) have a linear phase shift within their passband, meaning that increase in order will not necessarily impact the phase distortion to the output signal. However, a tradeoff is that the attenuation within the transition band is not as steep compared to IIR filters, and so to improve the signal the order of the filter must be improved dramatically (>50). This is a problem leading to increased processing and thus resulting in bulkier equipment, and more expensive hardware.
## Infinite Impulse Response (IIR)
IIR filters (Chebyshev, Butterworth) have a nonlinear phase shift within the passband, but at low enough orders (~10-20) the phase shift will not be large enough to have a significant impact on the output signal. The attenuation of IIR filters in the transition band is extremely steep even at lower orders, which make them ideal for this signal processor application.
Below is a phase and magnitude response of the chosen Butterworth filter, at passband of 500-600 Hz.
![phase-mag-response](https://github.com/yun-kim/cochlear-implant/raw/master/img/butterworth.PNG)
### Figure 2. Phase/Magnitude response of chosen Butterworth filter.

# Authors
Yun Kim, Paige Lavergne, Natasha Willis
