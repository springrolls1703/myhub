load local data files to Colab:
Method 1: Google Drive Method
Upload data file from system memory to Google drive.
Mount Google drive in Colab
from google.colab import drive drive.mount('/content/gdrive')
Then-> path = "/gdrive/My Drive/filename"
You can now access google drive files in Google Colab.
Method 2: Direct Load
from google.colab import files
def getLocalFiles():
_files = files.upload()
if len(_files) >0:
for k,v in _files.items():
open(k,'wb').write(v)
getLocalFiles()
Method 3: Using import files
from google.colab import files
uploaded = files.upload()


To get data from your system to colab try this:
from google.colab import files
uploaded = files.upload()
Choose the file you want to upload and hit enter and its done. For example, I have uploaded an image and displayed it using the code below:
import cv2
import numpy as np
from matplotlib import pyplot as plt
img = cv2.imread('image.jpg')
img_cvt = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
plt.imshow(img_cvt)
plt.show()