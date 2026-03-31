from ultralytics import YOLO

model = YOLO("yolov8n.pt")

results = model("test_image.jpg", show=True)