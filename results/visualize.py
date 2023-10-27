# This script generates a graphical representation of the runtime and max RSS
# for the figure 13 / figure 14 tests.


import numpy as np
import matplotlib.pyplot as plt


iters = [5000, 7500, 10000]
fig13_RM2_1_low_run = [877, 681, 1582]
fig13_RM2_1_med_run = [282, 425, 561]
fig13_RM2_1_high_run = [163, 242, 332]
fig13_RM2_2_low_run = [1288, 1688, 2267]
fig13_RM2_2_med_run = [712, 1066, 1427]
fig13_RM2_2_high_run = [422, 627, 839]
fig14_RM1_low_run = [268, 404, 541]
fig14_RM1_med_run = [221, 327, 444]
fig14_RM1_high_run = [175, 264, 352]
fig13_RM2_1_low_rss = [34.296, 34.304, 34.306]
fig13_RM2_1_med_rss = [34.301, 34.301, 34.301]
fig13_RM2_1_high_rss = [34.403, 34.403, 34.403]
fig13_RM2_2_low_rss = [70.279, 70.281, 70.279]
fig13_RM2_2_med_rss = [70.281, 70.278, 70.286]
fig13_RM2_2_high_rss = [70.380, 70.385, 70.383]
fig14_RM1_low_rss = [6.265, 6.266, 6.270]
fig14_RM1_med_rss = [6.269, 6.268, 6.273]
fig14_RM1_high_rss = [6.374, 6.374, 6.377]


def main():
    # RUNTIME

    # plt.plot(iters, fig13_RM2_1_med_run, 'o', color="black")
    # coef = np.polyfit(iters, fig13_RM2_1_med_run, 1)
    # fn = np.poly1d(coef)
    # plt.plot(iters, fn(iters), color="black", label=f"fig13_RM2_1_med")

    # plt.plot(iters, fig13_RM2_2_high_run, 'o', color="blue")
    # coef = np.polyfit(iters, fig13_RM2_2_high_run, 1)
    # fn = np.poly1d(coef)
    # plt.plot(iters, fn(iters), color="blue", label=f"fig13_RM2_2_high")

    # plt.plot(iters, fig14_RM1_med_run, 'o', color="green")
    # coef = np.polyfit(iters, fig14_RM1_med_run , 1)
    # fn = np.poly1d(coef)
    # plt.plot(iters, fn(iters), color="green", label=f"fig14_RM1_med")

    # plt.xlim(5000, 10000)
    # plt.ylim(200, 1000)
    # plt.xlabel("Numebr of iterations")
    # plt.ylabel("Runtime / sec")
    # plt.title(label="Runtime over iterations")
    # plt.legend()
    # plt.show()

    # RSS

    plt.plot(iters, fig13_RM2_1_med_rss, 'o', color="black")
    coef = np.polyfit(iters, fig13_RM2_1_med_rss, 1)
    fn = np.poly1d(coef)
    plt.plot(iters, fn(iters), color="black", label=f"fig13_RM2_1_med")

    plt.plot(iters, fig13_RM2_2_high_rss, 'o', color="blue")
    coef = np.polyfit(iters, fig13_RM2_2_high_rss, 1)
    fn = np.poly1d(coef)
    plt.plot(iters, fn(iters), color="blue", label=f"fig13_RM2_2_high")

    plt.plot(iters, fig14_RM1_med_rss, 'o', color="green")
    coef = np.polyfit(iters, fig14_RM1_med_rss, 1)
    fn = np.poly1d(coef)
    plt.plot(iters, fn(iters), color="green", label=f"fig14_RM1_med")

    plt.xlim(5000, 10000)
    plt.ylim(6, 71)
    plt.xlabel("Numebr of iterations")
    plt.ylabel("Max RSS / GB")
    plt.title(label="Max RSS over iterations")
    plt.legend()
    plt.show()


if __name__=='__main__':
    main()
