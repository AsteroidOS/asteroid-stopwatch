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

#include "StopwatchController.h"
#include <QSettings>
#include <time.h>

StopwatchController::StopwatchController(QObject *parent)
    : QObject(parent)
    , m_baseElapsed(-1)
    , m_startBoottime(0)
    , m_running(false)
{
    connect(&m_timer, &QTimer::timeout, this, &StopwatchController::elapsedChanged);
    m_timer.setInterval(100);

    QSettings s;
    qint64 baseElapsed    = s.value(QStringLiteral("baseElapsed"), -1).toLongLong();
    qint64 startBoottime  = s.value(QStringLiteral("startBoottime"), 0).toLongLong();
    QStringList lapStrs   = s.value(QStringLiteral("laps")).toStringList();

    for (const QString &str : lapStrs)
        m_laps << QVariant::fromValue(str.toLongLong());

    if (startBoottime > 0) {
        // Was running when app last closed. Any reboot makes CLOCK_BOOTTIME
        // less than the stored value so we cannot resume safely — invalidate.
        if (boottimeMs() >= startBoottime) {
            m_baseElapsed    = baseElapsed;
            m_startBoottime  = startBoottime;
            m_running        = true;
            m_timer.start();
        } else {
            m_laps.clear();
            save();
        }
    } else {
        m_baseElapsed = baseElapsed;
    }
}

QObject *StopwatchController::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new StopwatchController;
}

qint64 StopwatchController::boottimeMs() const
{
    struct timespec ts;
    clock_gettime(CLOCK_BOOTTIME, &ts);
    return (qint64)ts.tv_sec * 1000 + ts.tv_nsec / 1000000;
}

qint64 StopwatchController::elapsed() const
{
    if (m_baseElapsed < 0) return -1;
    if (m_running) return m_baseElapsed + (boottimeMs() - m_startBoottime);
    return m_baseElapsed;
}

void StopwatchController::save()
{
    QSettings s;
    s.setValue(QStringLiteral("baseElapsed"), QVariant::fromValue(m_baseElapsed));
    s.setValue(QStringLiteral("startBoottime"), QVariant::fromValue(m_startBoottime));
    QStringList lapStrs;
    for (const QVariant &v : m_laps)
        lapStrs << QString::number(v.toLongLong());
    s.setValue(QStringLiteral("laps"), lapStrs);
}

void StopwatchController::start()
{
    if (m_running) return;
    if (m_baseElapsed < 0) m_baseElapsed = 0;
    m_startBoottime = boottimeMs();
    m_running = true;
    m_timer.start();
    emit runningChanged();
    save();
}

void StopwatchController::stop()
{
    if (!m_running) return;
    m_baseElapsed   = elapsed();
    m_startBoottime = 0;
    m_running       = false;
    m_timer.stop();
    emit runningChanged();
    emit elapsedChanged();
    save();
}

void StopwatchController::reset()
{
    m_timer.stop();
    m_baseElapsed   = -1;
    m_startBoottime = 0;
    m_running       = false;
    m_laps.clear();
    emit runningChanged();
    emit elapsedChanged();
    emit lapsChanged();
    save();
}

void StopwatchController::recordLap()
{
    if (!m_running) return;
    m_laps.prepend(QVariant::fromValue(elapsed()));
    emit lapsChanged();
    save();
}
