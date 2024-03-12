FROM node:lts
WORKDIR /home/node/app

COPY ./package.json .
RUN npm install

COPY . .

EXPOSE 3000
CMD ["node", "--require ./instrumentation.js app.js"]

# node --require ./instrumentation.js app.js