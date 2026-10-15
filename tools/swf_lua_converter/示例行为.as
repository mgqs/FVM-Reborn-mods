package demo
{
    public class SimpleCard
    {
        public function SimpleCard() {}
        public function on_create(ctx:Object, state:Object):void
        {
            state.ticks = 0;
        }
        public function on_step(ctx:Object, state:Object):void
        {
            state.ticks = state.ticks + 1;
            if (state.ticks >= ctx.cycle)
            {
                api.shoot({sprite:"ice", damage:ctx.atk, speed:8, slow_ticks:180});
                state.ticks = 0;
            }
        }
    }
}
