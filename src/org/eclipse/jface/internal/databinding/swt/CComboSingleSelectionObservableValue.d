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
module org.eclipse.jface.internal.databinding.swt.CComboSingleSelectionObservableValue;
import org.eclipse.jface.internal.databinding.swt.SingleSelectionObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.swt.custom.CCombo;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;

/**
 * @since 1.0
 *
 */
public class CComboSingleSelectionObservableValue :
        SingleSelectionObservableValue {

    private SelectionListener selectionListener;

    /**
     * @param combo
     */
    public this(CCombo combo) {
        super(combo);
    }
    
    /**
     * @param realm
     * @param combo
     */
    public this(Realm realm, CCombo combo) {
        super(realm, combo);
    }

    private CCombo getCCombo() {
        return cast(CCombo) getWidget();
    }

    protected void doAddSelectionListener(Runnable runnable) {
        selectionListener = new class(runnable) SelectionListener {
            Runnable runnable_;
            this(Runnable r ){ runnable_=r; }
            public void widgetDefaultSelected(SelectionEvent e) {
                runnable_.run();
            }

            public void widgetSelected(SelectionEvent e) {
                runnable_.run();
            }
        };
        getCCombo().addSelectionListener(selectionListener);
    }

    protected int doGetSelectionIndex() {
        return getCCombo().getSelectionIndex();
    }

    protected void doSetSelectionIndex(int index) {
        getCCombo().setText(getCCombo().getItem(index));
    }

    /*
     * (non-Javadoc)
     *
     * @see org.eclipse.core.databinding.observable.value.AbstractObservableValue#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
        if (selectionListener !is null && !getCCombo().isDisposed()) {
            getCCombo().removeSelectionListener(selectionListener);
        }

    }
}
