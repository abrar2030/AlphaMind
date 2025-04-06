import pymc3 as pm
import arviz as az

class BayesianVaR:
    def __init__(self, returns):
        self.returns = returns
        
    def build_model(self):
        with pm.Model() as var_model:
            # Stochastic volatility
            sigma = pm.GARCH11('sigma', self.returns)
            
            # Regime switching
            states = pm.Categorical('states', p=np.ones(3)/3, shape=len(self.returns))
            mu = pm.Normal('mu', 0, 1, shape=3)
            
            # Likelihood
            pm.Normal(
                'returns', 
                mu=mu[states], 
                sigma=sigma, 
                observed=self.returns
            )
            
        self.trace = pm.sample(2000, tune=1000, cores=4)
        
    def calculate_var(self, alpha=0.05):
        post_pred = pm.sample_posterior_predictive(
            self.trace, var_model)
        return az.hdi(post_pred['returns'], alpha*2).sel(hdi='lower')