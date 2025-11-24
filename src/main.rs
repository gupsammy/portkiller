fn main() -> anyhow::Result<()> {
    env_logger::init();
    portkiller::run()
}
