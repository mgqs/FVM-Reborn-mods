function Enum_Init(){
	enum CARD_STATE{
		IDLE,
		ATTACK,
		GROW,
		READY,
		SLEEP,
		AWAKE,
		RELAX
	}
	enum CARD_DATA {
	    obj,        // 卡牌对象
	    spr,        // 卡牌精灵
	    cost,       // 使用消耗
	    cooldown,   // 冷却时间（帧数）
	    description // 卡牌描述
	}
	enum ATTACK_TYPE{
		PRODUCER,
		SHOOTER
	}
	enum ENEMY_STATE{
		IDLE,
		ATTACK,
		NORMAL,
		DEAD,
		ACTING,
		APPEAR,
		DIG
	}
	
	enum BOSS_STATE{
		APPEAR,
		IDLE,
		SKILL1,
		SKILL2,
		SKILL3,
		SKILL4,
		MOVE,
		LAUNCH,
		DROP,
		DISAPPEAR,
		STUN,
		DEATH
	}
}