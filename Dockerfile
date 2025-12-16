
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
RUN npm install pg --save
COPY . .
RUN npm run build
EXPOSE 1337
CMD ["npm", "run", "start"]
