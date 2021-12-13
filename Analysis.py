# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.0
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# %%
import pandas as pd
import matplotlib.pyplot as plt    


# %% [markdown]
# ## Evaporation Rate

# %%
df1 = pd.read_csv("evap_y+p_0.005to0.009.csv", header=6).rename(columns={
    'count turtles with [color = pink]': 'numPink',
    'count turtles with [color = yellow]': 'numYellow',
    '[step]': 'ticks',
})[['evaporation-rate', 'numPink', 'numYellow', 'ticks']]
df1.groupby(by='evaporation-rate').count()

# %%
df2 = pd.read_csv("evap_y+p_0.01to0.015.csv", header=6).rename(columns={
    'count turtles with [color = pink]': 'numPink',
    'count turtles with [color = yellow]': 'numYellow',
})[['evaporation-rate', 'numPink', 'numYellow', 'ticks']]
df2.groupby(by='evaporation-rate').count()

# %% [markdown]
# First let's get rid of 0.010 from df1

# %%
df1 = df1[df1['evaporation-rate'] < 0.010]

# %% [markdown]
# We need to downsample df1 so that there are only 50 repetitions for each evaporation rate. We must do this randomly.

# %%
df1 = df1.groupby('evaporation-rate').apply(lambda x: x.sample(50, replace=False, random_state=47)).reset_index(drop=True)
df1.groupby(by='evaporation-rate').count()

# %% [markdown]
# Now, let's join both together

# %%
df = pd.concat([df1,df2], axis=0)
df.groupby(by='evaporation-rate').count()

# %% [markdown]
# ### v.s. Population Yellow Pink

# %%
ax = df.boxplot(column=['numPink'], by='evaporation-rate', grid=False, )
ax.set_xlabel("Evaporation Rate")
ax.set_ylabel("Population Pink")
plt.title("Effect of Evaporation Rate on Pink Population at Crossover")
plt.suptitle('')
plt.show()

# %%
ax = df.boxplot(column=['numYellow'], by='evaporation-rate', grid=False, )
ax.set_xlabel("Evaporation Rate")
ax.set_ylabel("Population Yellow")
plt.title("Effect of Evaporation Rate on Yellow Population at Crossover")
plt.suptitle('')
plt.show()

# %% [markdown]
# ### v.s. Ticks to Crossover

# %%
df.loc[df['ticks']>1500, 'ticks'] = 1500

# %%
df.groupby(by='ticks').count().tail()

# %%
df.groupby(by='evaporation-rate').count()

# %%
ax = df.boxplot(column=['ticks'], by='evaporation-rate', grid=False)
ax.set_xlabel("Evaporation Rate")
ax.set_ylabel("Time to Cancer Domination")
plt.title("Effect of Evaporation Rate on Time to Cancer Domination")
plt.suptitle('')
plt.show()

# %% [markdown]
# ## Evaporation Rate v.s. Ticks to Crossover

# %%
df = pd.read_csv("CooperationAmongCancerCells evap_rate-table.csv", header=6)
df = df.groupby(by=['[run number]']).max()  # Recorded at every step so needed to just max out the values
df.head()

# %%
df.groupby('evaporation-rate').count()

# %%
ax = df.boxplot(column=['ticks'], by='evaporation-rate', grid=False)
ax.set_xlabel("Evaporation Rate")
ax.set_ylabel("Time to Cancer Domination")
plt.title("Effect of Evaporation Rate on Time to Cancer Domination")
plt.suptitle('')
plt.show()

# %% [markdown]
# ## Diffusion Rate v.s. Ticks to Crossover

# %%
df = pd.read_csv("CooperationAmongCancerCells diff rate exp-table.csv", header = 6)
df.head()

# %%

# %%
ax = df.boxplot(column=['ticks'], by='diffusion-rate', grid=False, )
ax.set_xlabel("Diffiusion Rate")
ax.set_ylabel("Time to Cancer Domination")
plt.title("Effect of Diffusion Rate on Time to Cancer Domination")
plt.suptitle('')
plt.show()

# %%
df[df['diffusion-rate'] == 1].std()

# %%
df1 = pd.read_csv("evap_y+p_0.005to0.009.csv", header=6).rename(columns={
    'count turtles with [color = pink]': 'numPink',
    'count turtles with [color = yellow]': 'numYellow'    
})

# %% [markdown]
# ## Heatmap

# %%
import seaborn as sns
from matplotlib.colors import LogNorm, Normalize

import numpy as np

# %%
df = pd.read_csv("CooperationAmongCancerCells heatmap-table.csv", header = 6)
df_pv = df.groupby(by=['evaporation-rate', 'diffusion-rate']).mean().reset_index().pivot(index='evaporation-rate', columns='diffusion-rate', values='ticks')
df_pv

# %%
mask = np.zeros_like(df_pv)
mask[[df_pv >= 1500]] = 1

# %%
g = sns.heatmap(df_pv, mask=mask, annot=False, fmt="g", cmap='viridis')  # add norm=LogNorm() for log normalization
g.set_facecolor("grey")
g.set(title="Time to Cancer Domination Across Evaporation and Diffusion Rates")
plt.show()

# %%
