videoReader = VideoReader('obj 1.mp4');
videoPlayer = vision.DeployableVideoPlayer;
videoPlayer.Size = "Custom";
videoPlayer.CustomSize = [1024 576];

faceDetector=vision.CascadeObjectDetector();

idx = 1;
while hasFrame(videoReader)
    currentFrame = readFrame(videoReader,idx);

    if idx!=1
        lastFrame = readFrame(videoReader);
    end

    videoPlayer(videoFrame);
    pause(1/videoReader.FrameRate);
    idx = idx+1;
end
release(videoPlayer);