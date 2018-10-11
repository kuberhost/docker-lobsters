FROM alpine:edge

RUN apk update && apk upgrade && \
    apk add bash libffi tzdata mariadb-connector-c-dev curl krb5 unzip busybox-extras && \
    apk add ruby ruby-dev ruby-io-console ruby-bigdecimal ruby-json ruby-irb ruby-etc nodejs yarn && \
    apk add ruby-nokogiri=1.8.4-r0 ruby-rake ruby-bundler && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

WORKDIR /opt/app

ADD ./lobsters/Gemfile ./lobsters/Gemfile.lock /opt/app/

RUN apk update && apk upgrade && \
    apk add git libffi-dev mysql-dev make gcc g++ python musl-dev linux-headers && \
    bundle install --retry 10 --system --without development test && \
    gem install puma --no-doc && \
    apk del git libffi-dev mysql-dev make gcc g++ python musl-dev linux-headers && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.gem && \
    rm -rf /root/.bundle && \
    rm -rf /root/.cache

COPY ./lobsters /opt/app/
COPY ./docker-assets/config/database.yml /opt/app/config/database.yml

ENV PORT=3000
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

RUN bundle exec rake assets:precompile && \
    rm -rf /opt/app/tmp/*

ENTRYPOINT ["sh", "-c"]
CMD ["rake db:create db:migrate db:seed && puma ./config.ru"]

