/*
 * Copyright (C) 2026 Timo Könnecke <github.com/moWerk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef STOPWATCHCONTROLLER_H
#define STOPWATCHCONTROLLER_H

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QQmlEngine>
#include <QJSEngine>

class StopwatchController : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StopwatchController)

    Q_PROPERTY(qint64 elapsed READ elapsed NOTIFY elapsedChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    // Each entry is a qint64 elapsed timestamp in milliseconds at the moment
    // the lap was recorded. Entries are prepended so index 0 is always the
    // most recent lap.
    Q_PROPERTY(QVariantList laps READ laps NOTIFY lapsChanged)

public:
    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    qint64 elapsed() const;
    bool running() const { return m_running; }
    QVariantList laps() const { return m_laps; }

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void recordLap();

signals:
    void elapsedChanged();
    void runningChanged();
    void lapsChanged();

private:
    explicit StopwatchController(QObject *parent = nullptr);
    qint64 boottimeMs() const;
    void save();

    QTimer m_timer;
    qint64 m_baseElapsed;
    qint64 m_startBoottime;
    bool m_running;
    QVariantList m_laps;
};

#endif // STOPWATCHCONTROLLER_H
