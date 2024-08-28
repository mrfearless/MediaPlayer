# ![](./assets/mediaplayerlogo.png) MediaPlayer

A basic media player application written in x86 and x64 assembler that utilizes the [MFPlayer-Library](https://github.com/mrfearless/MFPlayer-Library) - which consists of functions that wrap the [MFPlay](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/api/mfplay/) COM implementation of the [IMFPMediaPlayer](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/api/mfplay/nn-mfplay-imfpmediaplayer) and [IMFPMediaItem](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/api/mfplay/nn-mfplay-imfpmediaitem) objects.

![](./assets/mediaplayer_75.png)

# Features

- Supports audio and video media that is natively supported by the [Microsoft Media Foundation API](https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation)
- Player controls via toolbar buttons, menu or context menu: Play/Pause Toggle, Stop, Frame Step, Volume Mute/Unmute, Fullscreen toggle, About, Exit.
- Custom control for Volume slider.
- Custom control for Seekbar slider.
- Custom controls for Labels (for duration of media and current position).
- Fullscreen enter via toolbar button, menu, context menu or F11.
- Fullscreen exit via toolbar button, menu, context menu, F11 or Escape.
- Spacebar toggles play/pause.
- Open media via File menu, context menu, clicking screen logo, clicking play button or drag and drop.
- Uses the [FileDialog-Library](https://github.com/mrfearless/FileDialog-Library)

# Download

The latest releases can be downloaded [here](https://github.com/mrfearless/mediaplayer/releases).