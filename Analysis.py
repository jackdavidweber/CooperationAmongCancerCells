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

# %% [markdown]
# ## Evaporation Rate v.s. Population Yellow Pink

# %%
df = pd.read_csv("CooperationAmongCancerCells_y+p_exp-table.csv", header=6).rename(columns={
    'count turtles with [color = pink]': 'numPink',
    'count turtles with [color = yellow]': 'numYellow'    
})
df.head()

# %%
df.boxplot(column=['numPink', 'numYellow'], by='evaporation-rate', grid=False)

# %% [markdown]
# ## Evaporation Rate v.s. Ticks to Crossover

# %%
df = pd.read_csv("CooperationAmongCancerCells tick exp-table.csv", header=6)
df.head()

# %%
df.boxplot(column=['ticks'], by='evaporation-rate', grid=False)

# %%
