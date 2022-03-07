## pretzel (p)
<pre>
  ,-._.-, 
 ((_|'|_))
 ';_/_\_;'
   '- -'  
</pre>

A music playing TUI program often used for ricing purposes, the program plays on mpv and demands only few dependencies unlike other independent music players that require another bullshit installation of 50+ different packages into the system and telling you to pass a music server which is exhausting and infuriating to setup. Since most users have mpv and ffmpeg already installed, the configuration should be simple.

## Preview 
![img](https://user-images.githubusercontent.com/58134273/156930747-2b4f347f-3f7c-4538-9280-775d79cfd5c0.png)

## Installation

```
git clone https://github.com/crittles/pretzel
cd pretzel
chmod +x ./pretzel
./pretzel
```

## Usage
`pretzel *.mp3`

## Customization
 To edit the status of the time counter, paste this command to ~/.config/mpv/mpv.conf </br>
`term-status-msg="\nAV: ${time-pos} / ${duration} (${percent-pos}%)"` </br>
 
 see: https://mpv.io/manual/stable/#options-term-osd-bar </br>
<pre>
                   \       /            _\/_
                     .-'-.              //o\  _\/_
  _  ___  __  _ --_ /     \ _--_ __  __ _ | __/o\\ _
=-=-_=-=-_=-=_=-_= -=======- = =-=_=-=_,-'|"'""-|-,_
 =- _=-=-_=- _=-= _--=====- _=-=_-_,-"          |
jgs=- =- =-= =- = -  -===- -= - ."
</pre>
Background of the terminal can be changed by writing another ascii art into background.xml

## Images
For anyone who's struggling, this shows the difference between libsixel and chafa. If you wish to stick with chafa, you can replace those lines inside the code. Any tool that allow images to display in the terminal such as w3m or ueberzug may be possible.
<pre>
plunger() {
    img2sixel "/tmp/abc.png" \
    -w 161 -h 156 \
    --builtin-palette=xterm256 \
    
plunger() {
    chafa "/tmp/abc.png" --size 18x18
</pre>

## Dependencies
- ffmpeg </br>
- mpv </br>
- libsixel or chafa </br>

some links </br>
https://github.com/hpjansson/chafa/ </br>
https://github.com/saitoha/libsixel </br>
https://github.com/galatolofederico/st-sixel </br>
https://gist.github.com/saitoha/70e0fdf22e3e8f63ce937c7f7da71809 </br>
