        for window_index in range(round(fps / 10) - 1, len(feats[feature_num][0]), round(fps / 10)):
            if window_index > round(fps / 10) - 1:
                feats1 = np.concatenate((feats1.reshape(feats1.shape[0], feats1.shape[1]),
                                         np.hstack((np.mean((feats[feature_num][0:4, range(window_index - round(fps / 10), window_index)]), axis=1),
                                                    np.sum((feats[feature_num][4:7, range(window_index - round(fps / 10), window_index)]),
                                                           axis=1))).reshape(len(feats[0]), 1)), axis=1)
            else:
                feats1 = np.hstack((np.mean((feats[feature_num][0:4, range(window_index - round(fps / 10), window_index)]), axis=1),
                                    np.sum((feats[feature_num][4:7, range(window_index - round(fps / 10), window_index)]), axis=1))).reshape(
                    len(feats[0]), 1)