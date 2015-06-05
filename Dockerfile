FROM nginx
MAINTAINER Edilio Gallardo, edilio73@gmail.com

RUN apt-get update

RUN apt-get install -y git vim python python-pip supervisor

RUN git clone https://github.com/edilio/citizenship.git

RUN echo "DEBUG=1" > /citizenship/.env
RUN cd /citizenship && pip install -r requirements/python/base.txt
RUN cd /citizenship && ./manage.py collectstatic --noinput
RUN cd /citizenship && gunicorn -w 2 -b 127.0.0.1:8000 -n citizen citizenship.wsgi:application &

COPY  django-nginx.conf /etc/nginx/conf.d/default.conf

# restart nginx to load the config
RUN service nginx stop

COPY supervisord.conf /etc/supervisor/supervisord.conf
# start supervisor to run our wsgi server
CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

