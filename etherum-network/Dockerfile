FROM alpine:3.14
RUN apk update
RUN apk add --upgrade geth
ENV nodekeyhex=""
CMD exec bootnode -nodekeyhex $nodekeyhex