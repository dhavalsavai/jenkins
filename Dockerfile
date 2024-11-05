# Step 1: Use an official Node.js image as the base
FROM node:18-alpine as build

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Copy package.json and package-lock.json files
COPY package*.json ./

# Step 4: Install dependencies
RUN npm install

# Step 5: Copy the entire project to the container
COPY . .

# Step 6: Build the React app for production
RUN npm run build

# Step 7: Use a lightweight Nginx image to serve the app
FROM nginx:alpine

# Step 8: Copy the build files to Nginx's default location
COPY --from=build /app/build /usr/share/nginx/html

# Step 9: Expose port 3002
EXPOSE 3002

# Step 10: Start Nginx and serve the app
CMD ["nginx", "-g", "daemon off;"]

