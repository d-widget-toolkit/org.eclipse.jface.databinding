/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.provisional.swt.WorkQueue;

import java.lang.all;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;

/**
 * NON-API - Helper class to manage a queue of runnables to be posted to the UI thread in a way
 * that they are only run once.
 * @since 1.1
 *
 */
public class WorkQueue {
    
    private bool updateScheduled = false;

    private bool paintListenerAttached = false;

    private LinkedList pendingWork;

    private Display d;

    private Set pendingWorkSet;

    private Runnable updateJob;
    class UpdateJob : Runnable {
        public void run() {
            doUpdate();
            updateScheduled = false;
        }
    };

    private Listener paintListener;
    class PaintListener : Listener {
        public void handleEvent(Event event) {
            paintListenerAttached = false;
            d.removeFilter(SWT.Paint, this);
            doUpdate();
        }
    };

    /**
     * @param targetDisplay
     */
    public this(Display targetDisplay) {
pendingWork = new LinkedList();
pendingWorkSet = new HashSet();
updateJob = new UpdateJob();
paintListener = new PaintListener();
        d = targetDisplay;
    }

    private void doUpdate() {
        for (;;) {
            Runnable next;
            synchronized (pendingWork) {
                if (pendingWork.isEmpty()) {
                    break;
                }
                next = cast(Runnable) pendingWork.removeFirst();
                pendingWorkSet.remove(cast(Object)next);
            }

            next.run();
        }
    }

    /**
     * Schedules some work to happen in the UI thread as soon as possible. If
     * possible, the work will happen before the next control redraws. The given
     * runnable will only be run once. Has no effect if this runnable has
     * already been queued for execution.
     * 
     * @param work
     *            runnable to execute
     */
    public void runOnce(Runnable work) {
        synchronized (pendingWork) {
            if (pendingWorkSet.contains(cast(Object)work)) {
                return;
            }

            pendingWorkSet.add(cast(Object)work);

            asyncExec(work);
        }
    }

    /**
     * Schedules some work to happen in the UI thread as soon as possible. If
     * possible, the work will happen before the next control redraws. Unlike
     * runOnce, calling asyncExec twice with the same runnable will cause that
     * runnable to run twice.
     * 
     * @param work
     *            runnable to execute
     */
    public void asyncExec(Runnable work) {
        synchronized (pendingWork) {
            pendingWork.add(cast(Object)work);
            if (!updateScheduled) {
                updateScheduled = true;
                d.asyncExec(updateJob);
            }

            // If we're in the UI thread, add an event filter to ensure
            // the work happens ASAP
            if (Display.getCurrent() is d) {
                if (!paintListenerAttached) {
                    paintListenerAttached = true;
                    d.addFilter(SWT.Paint, paintListener);
                }
            }
        }
    }

    /**
     * Cancels a previously-scheduled runnable. Has no effect if the given
     * runnable was not previously scheduled or has already executed.
     * 
     * @param toCancel
     *            runnable to cancel
     */
    public void cancelExec(Runnable toCancel) {
        synchronized (pendingWork) {
            pendingWork.remove(cast(Object)toCancel);
            pendingWorkSet.remove(cast(Object)toCancel);
        }
    }

    /**
     * Cancels all pending work.
     */
    public void cancelAll() {
        synchronized (pendingWork) {
            pendingWork.clear();
            pendingWorkSet.clear();
        }
    }
}
