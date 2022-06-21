/*
    SPDX-FileCopyrightText: 2007 Paolo Capriotti <p.capriotti@gmail.com>
    SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef PACKAGELISTMODEL_H
#define PACKAGELISTMODEL_H

#include "abstractimagelistmodel.h"

namespace KPackage
{
class ImagePackage;
}

/**
 * List KPackage wallpapers, usually in a folder.
 */
class PackageListModel : public AbstractImageListModel
{
    Q_OBJECT

public:
    explicit PackageListModel(const QSize &targetSize, QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    /**
     * @path Package folder path
     */
    int indexOf(const QString &path) const override;

    void load(const QStringList &customPaths = {}) override;

public Q_SLOTS:
    QStringList addBackground(const QString &path) override;
    QStringList removeBackground(const QString &path) override;

private Q_SLOTS:
    void slotHandlePackageFound(const QList<KPackage::ImagePackage> &packages);

private:
    QList<KPackage::ImagePackage> m_packages;

    friend class PackageListModelTest;
};

#endif // PACKAGELISTMODEL_H
