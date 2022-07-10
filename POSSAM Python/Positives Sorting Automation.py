# author: Richard Kim

import os
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import datetime

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

with open('list of barcodes.txt') as f:
    list_of_barcodes = f.readlines()

list_of_barcodes = list(map(str.strip, filter(lambda x: x != '\n', list_of_barcodes)))

print(f'Number of barcodes scanned into list_of_barcodes: {len(list_of_barcodes)}')

# Austin Public Health: List of Patient ZIP codes that need to be classified to APH
aph_zipcodes = list(map(str, [76574, 78605, 78610, 78612, 78613, 78615, 78616, 78617, 78620, 78621, 78626, 78628, 78634,
                              78640, 78641, 78642, 78644, 78645, 78652, 78653, 78654, 78660, 78663, 78664, 78665, 78669,
                              78681, 78701, 78702, 78703, 78704, 78705, 78712, 78717, 78719, 78721, 78722, 78723, 78724,
                              78725, 78726, 78727, 78728, 78729, 78730, 78731, 78732, 78733, 78734, 78735, 78736, 78737,
                              78738, 78739, 78741, 78742, 78744, 78745, 78746, 78747, 78748, 78749, 78750, 78751, 78752,
                              78753, 78754, 78756, 78757, 78758, 78759]))
# Houston: List of Testing Site IDs of Houston Testing Sites.
houston_testing_site_ids = [31030, 30437, 17954, 29966, 28551, 6966, 6967, 8861, 8868, 29344, 24534, 29317, 22753,
                            29343, 29266, 10818, 27233, 31580, 31581, 26823, 31579, 24459, 28703, 28862, 25566, 30673,
                            31172, 15333, 29267, 10040, 24703, 28748, 24544, 31614, 17836, 28775, 28774, 24541, 30596,
                            27585]


def sorting(row):
    # classification function used to sort samples to its appropriate positive rack
    if row['appointment_result'] == 'POSITIVE':
        if row['site_state'] == 'NM':
            if row['cn'] < 30:
                return 'Strong New Mexico'
            else:
                return 'Weak New Mexico'
        elif row['Testing Site ID'] in houston_testing_site_ids and row['cn'] < 26:
            return 'Houston'
        elif row['patients_zipcode'] in aph_zipcodes and row['cn'] < 30:
            return 'Austin Public Health'
        elif row['cn'] < 26:
            return 'Strong'
        elif row['cn'] >= 26:
            return 'Weak'
        else:
            return 'error1'
    elif row['appointment_result'] in ['NEGATIVE', 'INDETERMINATE']:
        return 'Negative rack'
    elif row['Result'] in ['QNS', 'TNP']:
        return 'QNS/TNP'
    return 'error2'  # most likely not resulted ones.


def color_scheme(sr):
    # color scheme used for plotting
    return {'Strong New Mexico': 'indianred',
            'Weak New Mexico': 'gold',
            'Strong': 'royalblue',
            'Weak': 'lightskyblue',
            'Houston': 'mediumpurple',
            'Austin Public Health': 'forestgreen',
            'Negative rack': 'silver',
            'QNS/TNP': 'dimgrey',
            'error1': 'white',
            'error2': 'white'}[sr]


def acronym(sr):
    # acronym used for plotting
    return {'Strong New Mexico': 'Str\nNM',
            'Weak New Mexico': 'Wk\nNM',
            'Strong': 'Str',
            'Weak': 'Wk',
            'Houston': 'Hou',
            'Austin Public Health': 'APH',
            'Negative rack': 'Neg',
            'QNS/TNP': 'QNS/\nTNP',
            'error1': 'Err1',
            'error2': 'Err2'}[sr]


well_pos = [i + str(j) for i in 'ABCDEFGH' for j in range(1, 13)][:len(list_of_barcodes)]
samples = pd.DataFrame(
    {'barcodes': list_of_barcodes, 'well_pos': well_pos, 'sorting_order': range(len(list_of_barcodes))})

possible_ct_files, possible_phi_files, possible_ts_files = list(), list(), list()
with os.scandir() as it:
    for entry in it:
        if entry.name.startswith('cn_and_ct_values_'):
            possible_ct_files.append(entry.name)
        elif entry.name.startswith('test_kits_possam_doh_phi__'):
            possible_phi_files.append(entry.name)
        elif entry.name.startswith('query_result'):
            possible_ts_files.append(entry.name)
ct_csv = max(possible_ct_files, key=os.path.getmtime)
phi_csv = max(possible_phi_files, key=os.path.getmtime)
testing_site_csv = max(possible_ts_files, key=os.path.getmtime)

phi = pd.read_csv(phi_csv)
phi.fillna(value={'patients_zipcode': 10000}, inplace=True)
phi.loc[:, 'patients_zipcode'] = phi.patients_zipcode.apply(lambda x: str(x)[:5])  # only need first five digits
ts = pd.read_csv(testing_site_csv)
ct = pd.read_csv(ct_csv)
ct.loc[:, 'sample_resulted_at'] = ct['sample_resulted_at'].apply(pd.to_datetime)
ct_new = pd.DataFrame(columns=ct.columns)

for barcode in list_of_barcodes:
    if len(ct.loc[ct['test_kit_barcode'] == barcode]) == 0:  # sample not resulted yet. Missed Exceptions.
        dummy = pd.DataFrame(columns=ct.columns)
        dummy.loc[0, 'test_kit_barcode'] = barcode
        dummy.loc[0, 'appointment_result'] = 'MISSED EXCEPTION'
        ct_new = ct_new.append(dummy)
        del dummy
    elif len(ct.loc[ct['test_kit_barcode'] == barcode]) == 1:
        ct_new = ct_new.append(ct.loc[ct['test_kit_barcode'] == barcode])
    else:
        # samples repeated. take the second result.
        # If it was ran three or more times by accident, it still takes the second result
        ct_new = ct_new.append(ct.loc[ct['test_kit_barcode'] == barcode].reset_index(drop=True) \
                               .sort_values(by='sample_resulted_at').loc[1])

# join all four dataframes indexed on test kit barcodes
df = samples.set_index('barcodes') \
    .join(
    ct_new[['test_kit_barcode', 'cn', 'site_state', 'site_county', 'site_city', 'sample_result', 'appointment_result']] \
    .set_index('test_kit_barcode')) \
    .join(phi[['barcode_id', 'patients_zipcode']].set_index('barcode_id')) \
    .join(ts[['Test Kits → Barcode', 'Testing Site ID', 'Result']].set_index('Test Kits → Barcode')) \
    .reset_index()

df['sorting_rack'] = df.apply(lambda row: sorting(row), axis=1)

df2 = df.sort_values('sorting_order')[['barcodes', 'well_pos', 'sorting_rack', 'cn', 'Result',
                                       'site_state', 'site_county', 'site_city']].copy()

print('Following is the appropriate positive racks found and the number of samples belonging to each rack.')
print(df2.sorting_rack.value_counts())

# preparing dataframe for plotting purpose
radius = 2
spacing = 1

df3 = pd.DataFrame({'sorting_rack': df2.copy().sorting_rack,
                    'grid_xpos': (list(range(12)) * 8)[:len(df2)],
                    'grid_ypos': [i for i in range(7, -1, -1) for _ in range(12)][:len(df2)]})
df3.loc[:, 'plt_xpos'] = df3.grid_xpos.apply(lambda x: (2 * radius + spacing) * x)
df3.loc[:, 'plt_ypos'] = df3.grid_ypos.apply(lambda y: (2 * radius + spacing) * y)
df3.loc[:, 'well_color'] = df3.sorting_rack.apply(color_scheme)
df3.loc[:, 'sorting_rack_acronym'] = df3.sorting_rack.apply(acronym)

# plotting df3 using matplotlib

fig, ax1 = plt.subplots(figsize=(30, 20), facecolor='white')

# assuming bottom left is 0,0

ax1.set_xlim(left=0 - radius - spacing, right=23 * radius + 12 * spacing)
ax1.set_ylim(bottom=0 - radius - spacing, top=15 * radius + 8 * spacing)

for i in range(len(df3)):
    ax1.add_patch(plt.Circle(xy=(df3.loc[i].plt_xpos, df3.loc[i].plt_ypos),
                             radius=radius,
                             edgecolor='black',
                             facecolor=df3.loc[i].well_color))
    plt.text(x=df3.loc[i].plt_xpos, y=df3.loc[i].plt_ypos,
             s=df3.loc[i].sorting_rack_acronym,
             ha='center', va='center', fontsize=30)
for x, y in map(lambda x: ((2 * radius + spacing) * x[0], (2 * radius + spacing) * x[1]),
                [(x, y) for y in range(7, -1, -1) for x in range(12)][len(df3):]):
    ax1.add_patch(plt.Circle(xy=(x, y),
                             radius=radius,
                             edgecolor='black',
                             facecolor='white'))

for y, txt in list(zip(map(lambda x: (2 * radius + spacing) * x, range(7, -1, -1)), 'ABCDEFGH')):
    plt.text(x=-2 * radius, y=y,
             s=txt, ha='center', va='center', fontsize=30)

for x, txt in list(zip(map(lambda x: (2 * radius + spacing) * x, range(12)), map(str, range(1, 13)))):
    plt.text(x=x, y=-2 * radius,
             s=txt, ha='center', va='center', fontsize=30)

plt.axis('off')

ct = datetime.datetime.now()
fig.savefig(f'Image of Positive Rack - starting from {list_of_barcodes[0]} created on {ct.strftime("%Y-%m-%d %H-%M-%S")}.png')

fig2, ax2 = plt.subplots(figsize=(12,4))
ax2.axis('tight')
ax2.axis('off')
the_table = ax2.table(cellText=df2.values,colLabels=df2.columns,loc='center')

pp = PdfPages(f'Table of Positive Rack - starting from {list_of_barcodes[0]} created on {ct.strftime("%Y-%m-%d %H-%M-%S")}.pdf')
pp.savefig(fig2, bbox_inches='tight')
pp.close()