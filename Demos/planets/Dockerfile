# Use the nginx:alpine base image
FROM nginx:alpine

LABEL VERSION="0.0.2"

# Copy the web app files to the Nginx html directory
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
# CMD ["nginx", "-g", "daemon off;"]