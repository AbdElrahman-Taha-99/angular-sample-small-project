# Use a Node.js image to build the Angular app
FROM node:18 AS build 

WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./ 
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Angular app
RUN npm run build --configuration=production

# Use Nginx to serve the built Angular app
FROM nginx:alpine
COPY --from=build /app/dist/angular-sample-small-project /usr/share/nginx/html

# Copy the default Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port Nginx runs on
EXPOSE 80 

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
