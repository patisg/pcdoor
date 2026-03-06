FROM dart:stable

ENV PATH="$PATH:$HOME/.pub-cache/bin"

WORKDIR /app

COPY . .

RUN pub get

RUN flutter build web

CMD ["flutter", "run", "--release", "--web"]
