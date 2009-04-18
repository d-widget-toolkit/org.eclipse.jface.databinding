/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *     Ashley Cambrell - bug 198904
 *******************************************************************************/
module org.eclipse.jface.internal.databinding.swt.ListSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.SingleSelectionObservableValue;

import java.lang.all;

import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.List;

/**
 * @since 1.0
 * 
 */
public class ListSingleSelectionObservableValue :
        SingleSelectionObservableValue {

    private SelectionListener selectionListener;

    /**
     * @param combo
     */
    public this(List combo) {
        super(combo);
    }

    private List getList() {
        return cast(List) getWidget();
    }

    protected void doAddSelectionListener(Runnable runnable) {
        selectionListener = new class(runnable) SelectionListener {
            Runnable runnable_;
            this(Runnable r){ runnable_ = r; }
            public void widgetDefaultSelected(SelectionEvent e) {
                runnable_.run();
            }

            public void widgetSelected(SelectionEvent e) {
                runnable_.run();
            }
        };
        getList().addSelectionListener(selectionListener);
    }

    protected int doGetSelectionIndex() {
        return getList().getSelectionIndex();
    }

    protected void doSetSelectionIndex(int index) {
        getList().setSelection(index);
    }

    /*
     * (non-Javadoc)
     *
     * @see org.eclipse.core.databinding.observable.value.AbstractObservableValue#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
        if (selectionListener !is null && !getList().isDisposed()) {
            getList().removeSelectionListener(selectionListener);
        }
    }
}
