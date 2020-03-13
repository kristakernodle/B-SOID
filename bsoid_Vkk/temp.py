# %%

# @title B-SOiD_ASSIGN { vertical-output: true, display-mode: "form" }

def bsoid_assign(clean_dlc_output, fps, comp, kclass, it, *args, **kwargs):
    win_len = np.int(np.round(0.05 / (1 / fps)) * 2 - 1)
    print('Obtaining features from dataset... \n')
    start_time = time.time()
    feats = list()
    for m in range(len(clean_dlc_output)):
        ## Obtain features, 4 distance features and 3 time-varying speed/angle features
        ## I WILL HAVE TO CHANGE THIS PART, LET'S SEE WHAT I CAN DO
        number_csvFiles = len(clean_dlc_output[m])  #
        fpd = clean_dlc_output[m][:, 2:4] - clean_dlc_output[m][:, 4:6]

        cfp = np.vstack(((clean_dlc_output[m][:, 2] + clean_dlc_output[m][:, 4]) / 2, (clean_dlc_output[m][:, 3] + clean_dlc_output[m][:, 5]) / 2)).T
        cfpLen = len(cfp)
        cfp_pt = np.vstack(([cfp[:, 0] - clean_dlc_output[m][:, 10], cfp[:, 1] - clean_dlc_output[m][:, 11]])).T
        chp = np.vstack((((clean_dlc_output[m][:, 6] + clean_dlc_output[m][:, 8]) / 2), ((clean_dlc_output[m][:, 7] + clean_dlc_output[m][:, 9]) / 2))).T
        chp_pt = np.vstack(([chp[:, 0] - clean_dlc_output[m][:, 10], chp[:, 1] - clean_dlc_output[m][:, 11]])).T
        sn_pt = np.vstack(([clean_dlc_output[m][:, 0] - clean_dlc_output[m][:, 10], clean_dlc_output[m][:, 1] - clean_dlc_output[m][:, 11]])).T

        fpd_norm = np.zeros(number_csvFiles)
        cfp_pt_norm = np.zeros(number_csvFiles)
        chp_pt_norm = np.zeros(number_csvFiles)
        sn_pt_norm = np.zeros(number_csvFiles)
        fpd_norm_smth = np.zeros(number_csvFiles)
        sn_cfp_norm_smth = np.zeros(number_csvFiles)
        sn_chp_norm_smth = np.zeros(number_csvFiles)
        sn_pt_norm_smth = np.zeros(number_csvFiles)
        for i in range(1, number_csvFiles):
            fpd_norm[i] = np.array(np.linalg.norm(clean_dlc_output[m][i, 2:4] - clean_dlc_output[m][i, 4:6]))
            cfp_pt_norm[i] = np.linalg.norm(cfp_pt[i, :])
            chp_pt_norm[i] = np.linalg.norm(chp_pt[i, :])
            sn_pt_norm[i] = np.linalg.norm(sn_pt[i, :])
        fpd_norm_smth = boxcar_center(fpd_norm, win_len)
        sn_cfp_norm_smth = boxcar_center(sn_pt_norm - cfp_pt_norm, win_len)
        sn_chp_norm_smth = boxcar_center(sn_pt_norm - chp_pt_norm, win_len)
        sn_pt_norm_smth = boxcar_center(sn_pt_norm, win_len)
        sn_pt_ang = np.zeros(number_csvFiles - 1)
        sn_disp = np.zeros(number_csvFiles - 1)
        pt_disp = np.zeros(number_csvFiles - 1)
        sn_pt_ang_smth = np.zeros(number_csvFiles - 1)
        sn_disp_smth = np.zeros(number_csvFiles - 1)
        pt_disp_smth = np.zeros(number_csvFiles - 1)
        for k in range(0, number_csvFiles - 1):
            b_3d = np.hstack([sn_pt[k + 1, :], 0])
            a_3d = np.hstack([sn_pt[k, :], 0])
            c = np.cross(b_3d, a_3d)
            sn_pt_ang[k] = np.dot(np.dot(np.sign(c[2]), 180) / np.pi,
                                  math.atan2(np.linalg.norm(c), np.dot(sn_pt[k, :], sn_pt[k + 1, :])))
            sn_disp[k] = np.linalg.norm(clean_dlc_output[m][k + 1, 0:2] - clean_dlc_output[m][k, 0:2])
            pt_disp[k] = np.linalg.norm(clean_dlc_output[m][k + 1, 10:12] - clean_dlc_output[m][k, 10:12])
        sn_pt_ang_smth = boxcar_center(sn_pt_ang, win_len)
        sn_disp_smth = boxcar_center(sn_disp, win_len)
        pt_disp_smth = boxcar_center(pt_disp, win_len)
        feats.append(np.vstack((sn_cfp_norm_smth[1:], sn_chp_norm_smth[1:], fpd_norm_smth[1:],
                                sn_pt_norm_smth[1:], sn_pt_ang_smth[:], sn_disp_smth[:], pt_disp_smth[:])))
    print("--- Feature extraction took %s seconds ---" % (time.time() - start_time))
    # Feature compilation
    start_time = time.time()
    if comp == 0:
        f_10fps = list()
        tsne_feats = list()
        labels = list()
    for n in range(0, len(feats)):
        feats1 = np.zeros(len(clean_dlc_output[n]))
        for k in range(round(fps / 10) - 1, len(feats[n][0]), round(fps / 10)):
            if k > round(fps / 10) - 1:
                feats1 = np.concatenate((feats1.reshape(feats1.shape[0], feats1.shape[1]),
                                         np.hstack((np.mean((feats[n][0:4, range(k - round(fps / 10), k)]), axis=1),
                                                    np.sum((feats[n][4:7, range(k - round(fps / 10), k)]),
                                                           axis=1))).reshape(len(feats[0]), 1)), axis=1)
            else:
                feats1 = np.hstack((np.mean((feats[n][0:4, range(k - round(fps / 10), k)]), axis=1),
                                    np.sum((feats[n][4:7, range(k - round(fps / 10), k)]), axis=1))).reshape(
                    len(feats[0]), 1)
        print("--- Feature compilation took %s seconds ---" % (time.time() - start_time))
        if comp == 1:
            if n > 0:
                f_10fps = np.concatenate((f_10fps, feats1), axis=1)
            else:
                f_10fps = feats1
        else:
            f_10fps.append(feats1)
            if len(f_10fps[n]) < 15000:
                p = 50
                exag = 12
                lr = 200
            else:
                p = round(f_10fps[n].shape[1] / 300)
                exag = round(f_10fps[n].shape[1] / 1200)
                lr = round(np.log(f_10fps[n].shape[1]) / 0.04)
            start_time = time.time()
            ## Run t-SNE dimensionality reduction
            np.random.seed(0)  # For reproducibility
            print(
                'Running the compiled data through t-SNE collapsing the 7 features onto 3 action space coordinates... \n')
            tsne_feats_i = TSNE(n_components=3, perplexity=p, early_exaggeration=exag, learning_rate=lr,
                                n_jobs=8).fit_transform(f_10fps[n].T)
            tsne_feats.append(tsne_feats_i)
            print("--- TSNE embedding took %s seconds ---" % (time.time() - start_time))

            ## Run a Gaussian Mixture Model Expectation Maximization to group the t-SNE clusters
            start_time = time.time()
            gmm = mixture.GaussianMixture(n_components=kclass, covariance_type='full', tol=0.001, reg_covar=1e-06,
                                          max_iter=100, n_init=it, init_params='random').fit(tsne_feats_i)
            grp = gmm.predict(tsne_feats_i)
            labels.append(grp)
            print("--- Gaussian mixtures took %s seconds ---" % (time.time() - start_time))
            print(" Plotting t-SNE with GMM assignments... ")
            uk = list(np.unique(labels))
            uniqueLabels = []
            for i in labels:
                indexVal = uk.index(i)
                uniqueLabels.append(indexVal)
            R = np.linspace(0, 1, len(uk))
            color = plt.cm.hsv(R)
            fig = go.Figure(
                data=[go.Scatter3d(x=tsne_feats_i[:, 0], y=tsne_feats_i[:, 1], z=tsne_feats_i[:, 2], mode='markers',
                                   marker=dict(size=2.5, color=color[uniqueLabels], opacity=0.8))])
            fig.show()
            print('TADA! \n')
    if comp == 1:
        if len(f_10fps) < 15000:
            p = 50
            exag = 12
            lr = 200
        else:
            p = round(f_10fps.shape[1] / 300)
            exag = round(f_10fps.shape[1] / 1200)
            lr = round(np.log(f_10fps.shape[1]) / 0.04)
        start_time = time.time()
        ## Run t-SNE dimensionality reduction
        np.random.seed(0)  # For reproducibility
        print('Running the compiled data through t-SNE collapsing the 7 features onto 3 action space coordinates... \n')
        tsne_feats = TSNE(n_components=3, perplexity=p, early_exaggeration=exag, learning_rate=lr,
                          n_jobs=8).fit_transform(f_10fps.T)
        print("--- TSNE embedding took %s seconds ---" % (time.time() - start_time))
        ## Run a Gaussian Mixture Model Expectation Maximization to group the t-SNE clusters
        start_time = time.time()
        gmm = mixture.GaussianMixture(n_components=kclass, covariance_type='full', tol=0.001, reg_covar=1e-06,
                                      max_iter=100, n_init=it, init_params='random').fit(tsne_feats)
        labels = gmm.predict(tsne_feats)
        print("--- Gaussian mixtures took %s seconds ---" % (time.time() - start_time))
        print(" Plotting t-SNE with GMM assignments... ")
        uk = list(np.unique(labels))
        uniqueLabels = []
        for i in labels:
            indexVal = uk.index(i)
            uniqueLabels.append(indexVal)
        R = np.linspace(0, 1, len(uk))
        color = plt.cm.hsv(R)
        fig = go.Figure(data=[go.Scatter3d(x=tsne_feats[:, 0], y=tsne_feats[:, 1], z=tsne_feats[:, 2], mode='markers',
                                           marker=dict(size=2.5, color=color[uniqueLabels], opacity=0.8))])
        fig.show()
        print('TADA! \n')

    return f_10fps, tsne_feats, np.array(uniqueLabels), fig