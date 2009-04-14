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

module org.eclipse.jface.databinding.swt.ISWTObservable;

import java.lang.all;

import org.eclipse.core.databinding.observable.IObservable;
import org.eclipse.swt.widgets.Widget;

/**
 * {@link IObservable} observing an SWT widget.
 * 
 * @since 1.1
 *
 */
public interface ISWTObservable : IObservable {
    
    /**
     * Returns the widget of this observable
     * 
     * @return the widget
     */
    public Widget getWidget();

}
