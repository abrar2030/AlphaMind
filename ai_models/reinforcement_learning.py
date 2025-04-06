class PortfolioGymEnv(gym.Env):
    def __init__(self, universe, transaction_cost=0.001):
        self.universe = universe
        self.action_space = spaces.Box(-1, 1, (len(universe),))
        self.observation_space = spaces.Dict({
            'prices': spaces.Box(-np.inf, np.inf, (len(universe), 10)),
            'volumes': spaces.Box(0, np.inf, (len(universe),)),
            'macro': spaces.Box(-np.inf, np.inf, (5,))
        })
        
    def step(self, action):
        # Calculate portfolio rebalancing
        new_weights = self._normalize_weights(action)
        cost = self._transaction_cost(new_weights)
        reward = self._sharpe_ratio(new_weights) - cost
        return self._get_obs(), reward, False, {}
    
    def _sharpe_ratio(self, weights):
        returns = np.dot(self.returns, weights)
        return (np.mean(returns) - 0.02) / np.std(returns)

class PPOAgent:
    def __init__(self, env):
        self.model = PPO(
            'MultiInputPolicy', env, 
            learning_rate=3e-4,
            n_steps=2048,
            batch_size=64,
            n_epochs=10,
            gamma=0.99,
            gae_lambda=0.95
        )
        
    def train(self, timesteps=1e6):
        self.model.learn(total_timesteps=timesteps)