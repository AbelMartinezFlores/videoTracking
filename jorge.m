videoReader = VideoReader('caras 2.avi');
videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);
objectFrame = readFrame(videoReader);
[a,b,c,d]=imcrop(objectFrame);
ancho=d(3);
alto=d(4);

objectRegion =d;
objectImage = insertShape(objectFrame,'rectangle',objectRegion,'Color','red');
figure;
imshow(objectImage);


title('Red box shows object region');
points = detectMinEigenFeatures(im2gray(objectFrame),'ROI',objectRegion);
puntos=points.Location;
x=puntos(1,1);
y=puntos(1,2);
pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
figure;
imshow(pointImage);

title('Detected interest points');
tracker = vision.PointTracker('MaxBidirectionalError',3);
initialize(tracker,points.Location,objectFrame);
while hasFrame(videoReader)
      frame = readFrame(videoReader);   
      [points,validity] = tracker(frame);
      out = insertMarker(frame,points(validity, :),'+');
      videoPlayer(out);
end
release(videoPlayer);