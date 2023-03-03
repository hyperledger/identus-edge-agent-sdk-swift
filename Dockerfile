FROM nginx:1.23.3
COPY . /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf /etc/nginx/conf.d

EXPOSE 80
