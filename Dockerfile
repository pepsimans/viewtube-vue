FROM node:15-alpine3.13 as build
WORKDIR /home/build

COPY package.json yarn.lock ./
RUN yarn install --pure-lockfile --link-duplicates --ignore-optional

COPY . .

RUN yarn build

RUN rm -rf node_modules server scripts shared types

FROM alpine:3.13 as runtime
WORKDIR /home/app

RUN apk add --no-cache nodejs-current yarn

COPY --from=build /home/build .

RUN yarn install --pure-lockfile --link-duplicates --ignore-optional --non-interactive --production && \
    yarn cache clean && \
    yarn modclean -n default:safe -r

ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "-r", "module-alias/register", "dist/server/main.js"]
