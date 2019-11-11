FROM elixir:1.9.1-slim as build

WORKDIR /var/app

COPY . ./

RUN mix local.rebar --force && \
    mix local.hex --force

RUN mix deps.get

ENV MIX_ENV=prod
RUN mix release --force

FROM elixir:1.9.1-slim
WORKDIR /var/app
COPY --from=build /var/app/_build ./

ENTRYPOINT ["./prod/rel/acme_bank/bin/acme_bank"]
CMD ["start"]
