# Canvas-Avatars-EXE

This executable will ask you for the following:

1) The subdomain of your canvas environment 
2) The Enviroment you want to import into (test or beta). You leave this blank for production
3) The SIS_ID of the course that has your avatars in it. In this course you will need to upload the IMAGES for users. Each image should be named the SIS_ID of the user it represents. 
4) The name of the CSV file that lists all of the SIS ids for the users that you want to update avatars for
5) An admin token

The CSV only needs one column called "user_id". Each row is the SIS USER ID for a user you want to update 
