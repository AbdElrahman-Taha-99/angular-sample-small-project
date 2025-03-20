# Use a Node.js image to build the Angular app
FROM node:18-alpine AS build-stage 

#Set working directory inside the container
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./ 
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Angular app
RUN npm run build --prod

# Use Nginx to serve the built Angular app
FROM nginx:alpine AS production-stage

#Set work directory inside the container
WORKDIR /usr/share/nginx/html

# Remove default Nginx static files
RUN rm -rf ./*

# Copy built Angular files from previous stage
COPY --from=build-stage /app/dist/angular-sample-small-project /usr/share/nginx/html
COPY --from=build-stage /app/dist/angular-sample-small-project/browser /usr/share/nginx/html

# Expose the port Nginx runs on
EXPOSE 80 

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
