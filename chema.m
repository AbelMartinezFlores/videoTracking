videoReader = VideoReader('obj 1.mp4');
videoPlayer = vision.DeployableVideoPlayer;
videoPlayer.Size = "Custom";
videoPlayer.CustomSize = [1024 576];

while hasFrame(videoReader)
    videoFrame = readFrame(videoReader);
    videoPlayer(videoFrame);
    pause(1/videoReader.FrameRate);
end
release(videoPlayer);