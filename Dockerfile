FROM docker.io/openjdk:26-ea-25-bookworm as builder
RUN mkdir -p /Minecraft
WORKDIR /Minecraft
ADD https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.228/neoforge-21.1.228-installer.jar /Minecraft/mc.jar
ADD https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar /Minecraft
RUN echo "eula=true" > eula.txt
COPY . /Minecraft
RUN java -jar packwiz-installer-bootstrap.jar -g -s server file:///Minecraft/pack.toml
RUN rm -r mods/*.toml
RUN rm index.toml pack.toml packwiz-installer-bootstrap.jar packwiz-installer.jar packwiz.json
RUN java -jar mc.jar --installServer
RUN rm mc.jar
RUN rm *.log
RUN rm user_jvm_args.txt
RUN rm run.bat run.sh
RUN mkdir world

FROM docker.io/alpine
RUN apk add openjdk21-jre-headless --no-cache
RUN apk add libc6-compat --no-cache
COPY --from=builder /Minecraft /Minecraft
WORKDIR /Minecraft
ENV RAM 4G
CMD ["sh", "-c", "java -Xmx$RAM @libraries/net/neoforged/neoforge/21.1.228/unix_args.txt '$@' nogui"]
