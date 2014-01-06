"Epsilon Image Process"

This repository is useful for taking a folder of images and creating member directories from them. The idea is to gradually integrate member photos into our chapter website. We aim to do so by taking photos of all of the pledges at one of their events and process them to create a folder for each member and add their photo. The name of the new directory should correlate to their unique member id. This information will have to be retrieved from our website, or gathered from an exported csv.

To run this program there are a few requirements.

First, you will need two csv files.
share/img/list/list.csv should resemble the following structure
```
img_id,name,email
3093,bob,bob@gmail.com
```

Second, 
share/roster/roster.csv
```
id,name,email
392,bob,bob@gmail.com
```

Lastly, share/img/img/ should hold all of the images for which you would like to create a directory. The directory names, by defualt, will be the ID value associated with each image. The ID value will be joined with the image name via the csv files.