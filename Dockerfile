# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/azurelinux/base/nodejs:24@sha256:20f7ab20fab66f75d70753ac87a8f8c966521d811b109786174e15f2615464c2 AS build
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci
COPY . ./
RUN npm run build

FROM mcr.microsoft.com/azurelinux/base/nginx:1.28@sha256:c56239548c77476a1f39591ad569d545a82ff037c23cd13754ac5a28ad1725c0 AS final
EXPOSE 8080
COPY --from=build /src/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf.template
CMD ["/bin/sh", "-c", "sed \"s|@BFF_BASE_URL@|${BFF_BASE_URL}|g\" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]
